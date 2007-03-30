From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [BUG] ethX misnumbered and one missing in mii-tool
Date: Fri, 30 Mar 2007 12:35:38 -0400
Message-ID: <20070330163538.GC3510@csclub.uwaterloo.ca>
References: <1175203383.6219.8.camel@localhost> <4807377b0703292121o6eef3bf2l998878cfd677d821@mail.gmail.com> <1175240543.6219.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDEV list <netdev@vger.kernel.org>
To: Andrei Popa <andrei.popa@i-neo.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csclub1.cs.uwaterloo.ca ([129.97.7.226]:34769 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753914AbXC3Qfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 12:35:39 -0400
Content-Disposition: inline
In-Reply-To: <1175240543.6219.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 30, 2007 at 10:42:23AM +0300, Andrei Popa wrote:
> ethtool reports the same

Is udev running and having fun renumbering interfaces as they are being
detected in order to keep "consistent" interface names?

--
Len Sorensen
