From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 5 Oct 2006 22:50:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610052247520.32762@d.namei>
References: <45256E25.6020201@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Eric Paris <eparis@redhat.com>, johnpol@2ka.mipt.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:48082 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751017AbWJFCum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 22:50:42 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <45256E25.6020201@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches look ok to me.  I've tested them and applied them to the git 
tree [1].

Stephen, please let me know if you see any problems.


-- 
James Morris
<jmorris@namei.org>


[1] Git - git://git.infradead.org/~jmorris/selinux-2.6.git
Web - http://git.infradead.org/?p=users/jmorris/selinux-2.6.git;a=summary

