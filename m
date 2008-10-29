From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: [PATCH] atl1: fix vlan tag regression
Date: Wed, 29 Oct 2008 10:45:45 -0500
Message-ID: <49088529.8060602@gmail.com>
References: <20081029154050.GA13726@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, csnook@redhat.com, jie.yang@atheros.com,
	ramon.casellas@cttc.es, netdev@vger.kernel.org, stable@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f18.google.com ([209.85.217.18]:37224 "EHLO
	mail-gx0-f18.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbYJ2Ppt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 11:45:49 -0400
Received: by gxk11 with SMTP id 11so2914470gxk.13
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 08:45:48 -0700 (PDT)
In-Reply-To: <20081029154050.GA13726@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> Commit 401c0aabec4b97320f962a0161a846d230a6f7aa introduced a regression
> in the atl1 driver by storing the VLAN tag in the wrong TX descriptor
> field.
> 
> This patch causes the VLAN tag to be stored in its proper location.

Argh.  The patch is whitespace damaged.  Will resubmit shortly.
