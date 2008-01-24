From: "Nathaniel Filardo" <nwfilardo@gmail.com>
Subject: Re: [Bugme-new] [Bug 9806] New: (tun dev) Impossible to deassert IFF_ONE_QUEUE or IFF_NO_PI
Date: Thu, 24 Jan 2008 12:12:56 -0500
Message-ID: <6540790d0801240912yad27b6eu1834209d6bd5e539@mail.gmail.com>
References: <bug-9806-10286@http.bugzilla.kernel.org/>
	 <20080124003356.ec51432a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_24026_14367318.1201194776983"
To: maxk@qualcomm.com, vtun@office.satix.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:20177 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbYAXRM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 12:12:59 -0500
Received: by mu-out-0910.google.com with SMTP id i10so240947mue.5
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2008 09:12:57 -0800 (PST)
In-Reply-To: <20080124003356.ec51432a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_24026_14367318.1201194776983
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Jan 24, 2008 3:33 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Wed, 23 Jan 2008 13:13:13 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=9806
> Thanks.   Could you please submit the patch via email?  Send it to
> all recipients of this email.

Attached.
--nwf;

------=_Part_24026_14367318.1201194776983
Content-Type: text/x-diff; name=tun.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fbtkcfn50
Content-Disposition: attachment; filename=tun.patch

LS0tIHR1bi5jLm9yaWcJMjAwOC0wMS0yMyAxNjowOToyNS4wMDAwMDAwMDAgLTA1MDAKKysrIHR1
bi5jCTIwMDgtMDEtMjMgMTY6MTI6MjYuMDAwMDAwMDAwIC0wNTAwCkBAIC01NDAsOSArNTQwLDEz
IEBACiAKIAlpZiAoaWZyLT5pZnJfZmxhZ3MgJiBJRkZfTk9fUEkpCiAJCXR1bi0+ZmxhZ3MgfD0g
VFVOX05PX1BJOworCWVsc2UKKwkJdHVuLT5mbGFncyAmPSB+VFVOX05PX1BJOwogCiAJaWYgKGlm
ci0+aWZyX2ZsYWdzICYgSUZGX09ORV9RVUVVRSkKIAkJdHVuLT5mbGFncyB8PSBUVU5fT05FX1FV
RVVFOworCWVsc2UKKwkJdHVuLT5mbGFncyAmPSB+VFVOX09ORV9RVUVVRTsKIAogCWZpbGUtPnBy
aXZhdGVfZGF0YSA9IHR1bjsKIAl0dW4tPmF0dGFjaGVkID0gMTsK
------=_Part_24026_14367318.1201194776983--
