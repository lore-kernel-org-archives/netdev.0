From: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: wireless: b43legacy: radio.c: Remove unused function
Date: Sat, 3 Jan 2015 15:51:30 +0100
Message-ID: <CA+icZUUfFr2PQjp4ppMNj5UQE3U7-ArmO1LSDoZZf5c1Y85OMw@mail.gmail.com>
References: <1420127170-28421-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CACna6rznUcqGTK0t1k=kjn0NVLycq865780ozyB+VYu78d_BSg@mail.gmail.com>
	<CACna6rxbGRdw7XSYvHAJGxJvMVwjVbAL4ynBM3m9rNggh7gCVQ@mail.gmail.com>
	<CA+icZUWOXMEyobZkudW9BEfkaWFTXQL9XF26g7oJMCzt=4==6g@mail.gmail.com>
	<CAKXHbyO70WdWekSYCY9spMbX2+_kdKTp3JoreDKpCdUBzFwYqw@mail.gmail.com>
	<CACna6rxTYUWvxvu0rFydWxkjbYdHfhV=o+9A+ViCpbV-LFx7fw@mail.gmail.com>
	<CAKXHbyMqTk=k7eieBNtAD+n6+4w3weL82twHBo-o8ebm_3+wvg@mail.gmail.com>
	<CA+icZUUJfemKC85=p7Huyw7xwfUdXBhePseJCnUKLx9edgpT4w@mail.gmail.com>
	<CAKXHbyPm+2gy3E_FAVY82ggvJhWe-E_xtrhgeAPxUyRS-FutaA@mail.gmail.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	b43-dev <b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKXHbyPm+2gy3E_FAVY82ggvJhWe-E_xtrhgeAPxUyRS-FutaA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 3, 2015 at 3:45 PM, Rickard Strandqvist
<rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org> wrote:
[ ... ]
>> > I just got one more complaining about my subject-line in "net: wireless: "
>> > I use some sed call for this, so it's easy to fix. I will now remove that
>> > part hereinafter.
>> > I check in Documentation/ but did not find any clear info for this.
>> >
>>
>> The easiest way to make (sub)maintainers happy is to check the git-log...
>>
>> $ git log --oneline /path/to/file
>>
>> ...and look how other contributors labeled their patches.
>>
>> [1] is the 1st address to look at on how to submit patches to Linux-kernel.
>> To promote the good work of Greg, see [2,3] for a video and tutorial
>> on that topic, too.
>>
>> - Sedat -
>>
>> [1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/SubmittingPatches
>> [2] https://www.youtube.com/watch?v=XXix80GCvpo
>> [3] https://github.com/gregkh/kernel-tutorial
>
>
>
> Hi Sedat
>
> Thanks for the tip :)
>
> To bad with the audio in the video thow. Have read SubmittingPatches before.
>

AFAICS there is another (earlier) video "Write and Submit your first
Linux kernel Patch" from FOSDEM 2010.

For German readers I can recommend the book from [2] (no I get no
money for promotion).

- Sedat -

[1] https://www.youtube.com/watch?v=LLBrBBImJt4
[2] http://www.opensourcepress.de/de/produkte/Git/33227/978-3-95539-119-5-

>
> But I have now added a line in my script that does a:
>
> git log -10 --oneline
>
> So I can at least see the other subjekt lines, and make adjustments if
> necessary.
>
>
>
> Kind regards
> Rickard Strandqvist
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
