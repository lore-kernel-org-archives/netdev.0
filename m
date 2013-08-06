From: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 6 Aug 2013 20:35:06 +0200
Message-ID: <CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com>
References: <CA+icZUX8OcTSOABO6Nbz5R6_5-m39rsYOpDqYBA7hf8LFvJLLA@mail.gmail.com>
	<1375797260.8219.21.camel@jlt4.sipsolutions.net>
	<CA+icZUUAJ25QybqHvxz7eubSLH6YuNjcc5zyU2O5Xi9vevMGkw@mail.gmail.com>
	<1375800617.8219.23.camel@jlt4.sipsolutions.net>
	<CA+icZUVbKpyuke6PRg3-60gOggsTb=3cNRz3Sy0RmvcZSuPaNw@mail.gmail.com>
	<1375801059.8219.24.camel@jlt4.sipsolutions.net>
	<CA+icZUXrRsXfeW9hqxTMkKW4TdNSBH-zE8-zX2Rd7HTAx5MvqQ@mail.gmail.com>
	<CA+icZUWijPJmNoqE22Msqcn7tRot3SB3e=KujMM7JNd-Om-oOw@mail.gmail.com>
	<1375802297.8219.25.camel@jlt4.sipsolutions.net>
	<CA+icZUVCFOS6SHonEqzaJyWCGCU4nqqGjBN0VbmV-=OoM+deZg@mail.gmail.com>
	<CA+icZUVuOqdZUGy2ALAF1CehOqYdr7rtEsXhqNvDtYEns2BuRQ@mail.gmail.com>
	<1375802993.8219.26.camel@jlt4.sipsolutions.net>
	<CA+icZUW6P9Z_7z+o+z=qBWSFzyU8tgtY0ou+rmLcEzWbn94OXA@mail.gmail.com>
	<CA+icZUW7LVzg7sM3O-w5oQpeaj=CT6MS6Q7cRZ1qK0h-Z4wZuw@mail.gmail.com>
	<1375804998.8219.27.camel@jlt4.sipsolutions.net>
	<CA+icZUVRgVfXUdJ1xoaN=nciqZDhV-f6EbH+6DS7HAh+My65oQ@mail.gmail.com>
	<CA+icZUUmQbovkwXcdEp6eu=WJkiuiyO8nDVwCHFUuPDbJqU7Kg@mail.gmail.com>
	<CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ@mail.gmail.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=e89a8f6427ce1c26e604e34baf6d
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--e89a8f6427ce1c26e604e34baf6d
Content-Type: text/plain; charset=UTF-8

On Tue, Aug 6, 2013 at 8:26 PM, Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Aug 6, 2013 at 6:51 PM, Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Tue, Aug 6, 2013 at 6:07 PM, Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> On Tue, Aug 6, 2013 at 6:03 PM, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
>>>> [reducing mailing lists - Stephen if you want off let us know]
>>>>
>>>> On Tue, 2013-08-06 at 17:58 +0200, Sedat Dilek wrote:
>>>>
>>>>> $ cat /proc/version
>>>>> Linux version 3.11.0-rc4-1-wl-20130805 (sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org@fambox)
>>>>> (gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #1 SMP Tue Aug 6
>>>>> 17:52:45 CEST 2013
>>>>>
>>>>> This kernel boots fine and has no WiFi problems.
>>>>>
>>>>> > You assume a breakage in a different area than wireless or network in general?
>>>>> >
>>>>>
>>>>> Any wild guess?
>>>>
>>>> Not really, but maybe you can pull the other trees on top again and see
>>>> if those broke it? I don't really think/hope so but it's possible that
>>>> one of my pending pull requests broke it, I guess?
>>>>
>>>
>>> Hmm, I pulled in latest for-john of mac80211(-next) and
>>> iwlwifi-(fixes|next) which did not help.
>>>
>>> I am testing next-20130805 and next-20130802 to identify which
>>> Linux-next release is BROKEN.
>>>
>>
>> GOOD: next-20130801 and next-20130802
>>
>> BROKEN: next-20130805 and next-20130806
>>
>> Comparing diffs between next-20130802 and next-20130805.
>>
>
> [ To Dave and CC netdev ]
>
> [ Full thread see [1] ]
>
> The diff was not very helpful.
>
> $ cd linux-next-20130805
>
> $ git log --oneline v3.11-rc4.. | grep "Merge remote-tracking" | egrep
> 'net-next|slave-dma|wireless'
> 7f84622 Merge remote-tracking branch 'net-next/master' <--- BAD
> (before slave-dma/next)
> 3580d24 Merge remote-tracking branch 'slave-dma/next' <--- GOOD (after
> net-next/master)
> 88825c7 Merge remote-tracking branch 'wireless/master' <--- GOOD
>
> So, the culprit commit seems to be in the merge of 'net-next/master'.
>
> ( BTW, disabling IPv6 in NM/wifi-setup did not change behaviour -
> still disconnected to AP. )
>
> - Sedat -
>
> [1] http://marc.info/?t=137579712800008&r=1&w=2

Attached is a diff comparing all new commits in next-20130805.
If one of the commits smells bad to you, please let me know.

- Sedat -

--e89a8f6427ce1c26e604e34baf6d
Content-Type: application/octet-stream;
	name="list-of-commits-from-net-next_next-20130802-VS-next-20130805.diff"
Content-Disposition: attachment;
	filename="list-of-commits-from-net-next_next-20130802-VS-next-20130805.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hk1g5ql01

LS0tIGxpc3Qtb2YtY29tbWl0cy1mcm9tLW5ldC1uZXh0LWluLW5leHQtMjAxMzA4MDIudHh0CTIw
MTMtMDgtMDYgMjA6Mjk6NDUuMzEyMzk1MzU5ICswMjAwCisrKyBsaXN0LW9mLWNvbW1pdHMtZnJv
bS1uZXh0LW5leHQtaW4tbmV4dC0yMDEzMDgwNS50eHQJMjAxMy0wOC0wNiAyMDoyNjowMy44Mjk3
MDQwMTMgKzAyMDAKQEAgLTEsMyArMSwyNiBAQAorZjI3MDcwMSBheDg4MTc5XzE3OGE6IGF2b2lk
IGNvcHkgb2YgdHggdGNwIHBhY2tldHMKK2ZiYTM2NzkgZmliX3J1bGVzOiByZW9yZGVyIHN0cnVj
dCBmaWJfcnVsZXMgZmllbGRzCis3M2Y1Njk4IGZpYl9ydWxlczogZml4IHN1cHByZXNzb3IgbmFt
ZXMgYW5kIGRlZmF1bHQgdmFsdWVzCiswYzA2NjdhIHZsYW46IGNsZWFudXAgdGhlIHVzYWdlIG9m
IHZsYW5fZGV2X3ByaXYoZGV2KQorOWU5NDAyZSBjbmljLCBibngyaTogRml4IGJ1ZyBvbiBzb21l
IGJueDJ4IGRldmljZXMgdGhhdCBkb24ndCBzdXBwb3J0IGlTQ1NJCis5OTE4ZDViIGJvbmRpbmc6
IG1vZGlmeSBvbmx5IG5laWdoX3Bhcm1zIG93bmVkIGJ5IHVzCis2MzEzNDgwIG5laWdoYm91cjog
cG9wdWxhdGUgbmVpZ2hfcGFybXMgb24gYWxsb2MgYmVmb3JlIGNhbGxpbmcgbmRvX25laWdoX3Nl
dHVwCis4YTg0OWJiIG5ldDogbmV0bGluazogbWlub3I6IHJlbW92ZSB1bnVzZWQgcG9pbnRlciBp
biBhbGxvY19wZ192ZWMKKzZlZjk0Y2YgZmliX3J1bGVzOiBhZGQgcm91dGUgc3VwcHJlc3Npb24g
YmFzZWQgb24gaWZncm91cAorZDFjNTNjOCBpY21wdjZfZmlsdGVyOiBhbGxvdyBJQ01QdjYgbWVz
c2FnZXMgd2l0aCBib2RpZXMgPCA0IGJ5dGVzCis5Y2MwOGFmIGljbXB2Nl9maWx0ZXI6IGZpeCAi
X2hkciIgaW5jb3JyZWN0bHkgYmVpbmcgYSBwb2ludGVyCitjNDgzZTAyIGFmX3BhY2tldDogc2lt
cGxpZnkgVkxBTiBmcmFtZSBjaGVjayBpbiBwYWNrZXRfc25kCitjYmQ4OWFjIGFmX3BhY2tldDog
Zml4IGZvciBzZW5kaW5nIFZMQU4gZnJhbWVzIHZpYSBwYWNrZXRfbW1hcAorMGY3NWIwOSBhZl9w
YWNrZXQ6IHdoZW4gc2VuZGluZyBldGhlcm5ldCBmcmFtZXMsIHBhcnNlIGhlYWRlciBmb3Igc2ti
LT5wcm90b2NvbAorZDI3ZmM3OCBzY3RwOiBEb24ndCBsb29rdXAgZHN0IGlmIHRyYW5zcG9ydCBk
c3QgaXMgc3RpbGwgdmFsaWQKKzE0MDlhOTMgZXRoZXJuZXQ6IENvbnZlcnQgbWFjIGFkZHJlc3Mg
dXNlcyBvZiA2IHRvIEVUSF9BTEVOCis1NzRlMmFmIGluY2x1ZGU6IENvbnZlcnQgZXRoZXJuZXQg
bWFjIGFkZHJlc3MgZGVjbGFyYXRpb25zIHRvIHVzZSBFVEhfQUxFTgorZTIxNjk3NSB1YXBpOiBD
b252ZXJ0IHNvbWUgdXNlcyBvZiA2IHRvIEVUSF9BTEVOCiszNzUzNDU2IHFsY25pYzogVXBkYXRl
IHZlcnNpb24gdG8gNS4yLjQ1Cis3OWRhNGQwIHFsY25pYzogRW5hYmxlIG1haWxib3ggaW50ZXJm
YWNlIGluIHBvbGwgbW9kZSB3aGVuIGludGVycnVwdHMgYXJlIG5vdCBhdmFpbGFibGUKKzA2OGE4
ZDEgcWxjbmljOiBSZXBsYWNlIHBvbGwgbW9kZSBtYWlsYm94IGludGVyZmFjZSB3aXRoIGludGVy
cnVwdCBiYXNlZCBtYWlsYm94IGludGVyZmFjZQorZTVjNGU2YyBxbGNuaWM6IEludGVycnVwdCBi
YXNlZCBkcml2ZXIgZmlybXdhcmUgbWFpbGJveCBtZWNoYW5pc20KK2I5YzExOTggcWxjbmljOiBF
bmhhbmNlIGRpYWdub3N0aWMgbG9vcGJhY2sgZXJyb3IgY29kZXMuCiAyNzhiMjA4IGJvbmRpbmc6
IGluaXRpYWwgUkNVIGNvbnZlcnNpb24KIDE1MDc3MjIgYm9uZGluZzogZmFjdG9yIG91dCBzbGF2
ZSBpZCB0eCBjb2RlIGFuZCBzaW1wbGlmeSB4bWl0IHBhdGhzCiA3OGE2NDZjIGJvbmRpbmc6IHNp
bXBsaWZ5IGJyb2FkY2FzdF94bWl0IGZ1bmN0aW9uCg==
--e89a8f6427ce1c26e604e34baf6d--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
