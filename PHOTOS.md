# Photographs

The site currently uses drawn illustrations. They are original, they match the
brand colours, and they will never look like stock photography. But photographs
of real people do something illustrations cannot: they make a visitor believe
there is a person behind the business.

This file is what you need to know before adding any.

## The one rule that matters legally

Every photograph on the site must be one you have the right to use commercially.
Pulling an image off a Google search is copyright infringement, and the people
who own stock libraries do go looking. Check the licence on every single image,
even from the free sites below, because individual photos sometimes carry extra
conditions.

## Where to get them free, for commercial use

- **Centre for Ageing Better image library** (ageing-better.org.uk). Free, and
  built specifically to show older adults realistically rather than as frail
  patients. This is the closest match to how Ageless talks about people. Start
  here.
- **Unsplash** (unsplash.com) and **Pexels** (pexels.com). Large, free,
  commercial use permitted. Quality varies. Search terms that work better than
  "elderly": *older adults at home*, *senior man cooking*, *woman 70s kitchen*,
  *adult daughter parent*.

If you would rather pay, a local photographer for a half day would give you
something no competitor can copy, and photographs of actual Ottawa and Toronto
homes would be worth more than any stock image.

## What to look for

- Somebody doing something ordinary and competent. Cooking, gardening, reading,
  on the phone, letting somebody in the front door.
- A real home, not a showroom or a care facility.
- Natural light, warm tones. It should sit next to the paper background without
  looking pasted on.
- Adult children in a couple of them, because they are the ones reading the site.

## What to avoid

This list matters more than the one above, because these are the images that
would contradict everything the copy says.

- Anyone looking sad, frail, confused, or staring out of a window.
- Hospital beds, wheelchairs presented as tragedy, clinical settings, scrubs.
- A hand on a shoulder from above. It reads as pity.
- Anything where the older person is being managed rather than living.
- Grey-haired models who are obviously 55 pretending to be 80.

## The rule you must not break

**Never label a stock photo as a client.** A caption like "Margaret, Ottawa" on
a stock image is a fabricated testimonial, and it is the fastest way to destroy
the trust the rest of the site is built on. Photographs may set a mood. They may
never make a claim.

## How to add them

1. Save each photo as a `.jpg` in the `images/` folder.
2. Resize to about 1200 pixels wide before uploading. A 6 MB photo from a phone
   will make the site slow on a mobile connection, and slow pages lose visitors.
3. Name them plainly: `photo-kitchen.jpg`, `photo-front-door.jpg`.

Then either send them to me and I will place them, or paste this yourself where
you want one, changing the filename and the description:

```html
<img class="photo" src="images/photo-kitchen.jpg" width="1200" height="800"
     alt="A woman in her seventies making tea in her own kitchen.">
```

The `alt` text is what a blind visitor hears in place of the picture, and what
shows if the image fails to load. Describe what is happening, plainly. Do not
write "image of" and do not leave it empty on a photograph.

## Suggested places, in order of impact

1. **Home hero**, beside or under the headline. The single highest-value photo.
2. **About page**, near the top. Since there is no photo of you, a warm image of
   the kind of home you work in does the job instead.
3. **How It Works**, one photo at the assessment step.
4. **Solutions**, one per section, if you find six good ones. Do not force it.
   Four strong photos beat six weak ones.
