From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/2] NET: fix memory leaks from security_secid_to_secctx()
Date: Wed, 1 Aug 2007 17:05:16 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708011705020.29184@us.intercode.com.au>
References: <20070801151257.475951538@hp.com> <20070801151557.264877461@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:43165 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752478AbXHBANv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 20:13:51 -0400
In-Reply-To: <20070801151557.264877461@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both patches applied to:

git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-2.6.git#for-akpm



-- 
James Morris
<jmorris@namei.org>
