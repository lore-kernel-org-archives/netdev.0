From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 1/2] netdev: driver: ethernet: add cpsw address lookup
 engine support
Date: Wed, 15 Feb 2012 14:04:46 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293178AAAE@DBDE01.ent.ti.com>
References: <1329113061-13026-1-git-send-email-mugunthanvnm@ti.com>
	<1329113061-13026-2-git-send-email-mugunthanvnm@ti.com>
 <20120213093115.481e556e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:53287 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086Ab2BOOEx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 09:04:53 -0500
In-Reply-To: <20120213093115.481e556e@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Monday, February 13, 2012 11:01 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 1/2] netdev: driver: ethernet: add cpsw address lookup
> engine support
> 
> On Mon, 13 Feb 2012 11:34:20 +0530
> Mugunthan V N <mugunthanvnm@ti.com> wrote:
> 
> > static struct ale_control_info ale_controls[] = {
> 
> Can you make this table const?
Agreed and will update it on next version patch set

With regards
Mugunthan V N
