From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: No network on Asus P5B (r8169)
Date: Wed, 11 Jul 2007 00:25:08 +0200
Message-ID: <20070710222508.GD3436@electric-eye.fr.zoreil.com>
References: <20070628234222.GA8180@electric-eye.fr.zoreil.com> <200707101845.24297.clemens.brunner@tugraz.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Clemens Brunner <clemens.brunner@tugraz.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41736 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753465AbXGJW3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 18:29:03 -0400
Content-Disposition: inline
In-Reply-To: <200707101845.24297.clemens.brunner@tugraz.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clemens Brunner <clemens.brunner@tugraz.at> :
[...]
> I just found out that everything is working just fine with a 64-bit Linux 
> kernel. I hope this helps you hunt down the error in the 32-bit version.
> https://bugzilla.novell.com/show_bug.cgi?id=288406

Does your setup exclude the "wake up" issue described in
http://gentoo-wiki.com/HARDWARE_RTL8168 ?

-- 
Ueimor
