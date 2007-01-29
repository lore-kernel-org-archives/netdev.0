From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: d80211: a patch for standalone d80211 tarball
Date: Mon, 29 Jan 2007 19:34:24 +0100
Message-ID: <a32f33a40701291034l1b304ac3x48fbf55f7e2d285c@mail.gmail.com>
References: <20070129184707.885764375.midnight@suse.cz>
	 <20070129174812.7D1E94849E@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"James Ketrenos" <jketreno@linux.intel.com>
To: "Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:35865 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbXA2Se2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 13:34:28 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2137026nfa
        for <netdev@vger.kernel.org>; Mon, 29 Jan 2007 10:34:27 -0800 (PST)
In-Reply-To: <20070129174812.7D1E94849E@silver.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This patch should be enough to allow creation of standalone d80211 tarball
> (i.e. version of d80211 that could be compiled without patching the vanilla
> kernel) after "invisible master interface" patches.

That looks very nice indeed, that saves me quite a big patch
I usually apply to the rt2x00-cvs version of d80211. :)

> It is completely untested.

I will put this patch into the rt2x00-cvs version of d80211 to see if
it works. :)

Thanks.

Ivo

P.S.

I have some d80211 patches in testing that would add support for:
 - software rts
 - software sequence
 - tx_header_room fixes

As soon as they are tested I'll send them to the list. :)
