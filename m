From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: slow samba performance
Date: Tue, 4 Sep 2007 22:37:42 +0200
Message-ID: <20070904203742.GB31783@electric-eye.fr.zoreil.com>
References: <46CC66D3.8030602@gmail.com> <20070822182116.GA5445@csy.ca> <46CC9290.3040501@gmail.com> <Pine.SOC.4.64.0708271631330.871@katana> <20070903210322.GB4444@electric-eye.fr.zoreil.com> <Pine.SOC.4.64.0709041402130.871@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bruce Cole <bacole@gmail.com>, netdev@vger.kernel.org
To: john@BlueSkyTours.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50006 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbXIDUlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2007 16:41:13 -0400
Content-Disposition: inline
In-Reply-To: <Pine.SOC.4.64.0709041402130.871@katana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

john@BlueSkyTours.com <john@BlueSkyTours.com> :
[...]
> 20070903-2.6.23-rc5-r8169-test.patch applied against 2.6.23-rc5 works fine.
> Performance is acceptable.

Does "acceptable" mean that there is a noticeable difference when compared
to the patch based on a busy-waiting loop ?

> Would you like me to *just* try patches 1 & 2, to help narrow down anything?

I expect patch #2 alone to be enough to enhance the performance. If it gets
proven, the patch would be a good candidate for a quick merge upstream.

-- 
Ueimor
