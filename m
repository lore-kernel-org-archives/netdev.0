From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169.c broke for me from 2.6.20.4 to 2.6.21
Date: Mon, 28 May 2007 00:32:02 +0200
Message-ID: <20070527223202.GA19946@electric-eye.fr.zoreil.com>
References: <20070502223136.GA19750@electric-eye.fr.zoreil.com> <463960CA.1080902@foks.8m.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jelle Foks <jelle@foks.8m.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50989 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755291AbXE0Wfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 May 2007 18:35:42 -0400
Content-Disposition: inline
In-Reply-To: <463960CA.1080902@foks.8m.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jelle Foks <jelle@foks.8m.com> :
[...]

Can you send the output of 'ethtool -e eth0' after applying the patch
below on top of 2.6.22-rc3:
http://www.fr.zoreil.com/people/francois/misc/20070527-2.6.22-rc3-r8169.patch

-- 
Ueimor
