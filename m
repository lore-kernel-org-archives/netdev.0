From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH v2 06/10] nl80211: Various checkpatch.pl spacing fixes
Date: Mon, 30 May 2016 16:06:26 +1000
Message-ID: <CAGRGNgUbMQ5eh3aYdcRmoO7Qea_XTKzSXLYjf1NEAu6ZdJLPVg@mail.gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
 <80c4512b4c5ca1f26ecda9785a456c4d0cf4f937.1464576022.git.kirtika.ruchandani@gmail.com>
 <CAGRGNgWYuEVnF7OG4GKJrnNNkn8DWaAor=ebbiwRbTZBP8qn5Q@mail.gmail.com> <CAA-b7a_X=-Nk0CUD4ayssKB6nzDF9e7iWwD2gandxar-G35ZzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Tina Ruchandani <ruchandani.tina@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33499 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbcE3GGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 02:06:46 -0400
In-Reply-To: <CAA-b7a_X=-Nk0CUD4ayssKB6nzDF9e7iWwD2gandxar-G35ZzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kirtika,

On Mon, May 30, 2016 at 4:04 PM, Kirtika Ruchandani
<kirtika.ruchandani@gmail.com> wrote:
>> Adding the brackets around the & expression doesn't look spacing
>> related to me. What's the exact warning this is fixing?
>
> From the commit message - "This patch also contains two hunks to fix
> 'line over 80 characters',
> that are spacing related". This is the second hunk, the first being
> the comments in the nl80211_fam
> definition. Should I resend with these two hunks omitted, or fix my wording?

That explains it, I missed that bit.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
