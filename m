From: James Morris <jmorris@namei.org>
Subject: Re: [Fireflier-devel] Re: [PATCH][RFC] Security marking
Date: Mon, 24 Apr 2006 08:56:29 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0604240855130.8523@d.namei>
References: <20060417184053.6D618378FD@localhost.localdomain>
 <Pine.LNX.4.64.0604172051510.20174@d.namei> <200604232157.59758.edwin@gurde.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="537530981-251661884-1145883389=:8523"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	fireflier-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:17892 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750753AbWDXM4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 08:56:33 -0400
To: =?iso-8859-1?q?T=F6r=F6k_Edwin?= <edwin@gurde.com>
In-Reply-To: <200604232157.59758.edwin@gurde.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--537530981-251661884-1145883389=:8523
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 23 Apr 2006, Török Edwin wrote:

> > This could be done with nfqueue, modular policy and a pretty simple tool.
> How do I determine if the policy needs to be changed? I.e. how do I determine 
> if the packet would be dropped? You say packets are silently dropped, won't 
> they generate an avc denied at least? (at least the first time?)

Actually, yes, you'll get avc messages.



-- 
James Morris
<jmorris@namei.org>
--537530981-251661884-1145883389=:8523--
