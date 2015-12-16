From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 01/15] i40e: Add support for client interface for IWARP
 driver
Date: Wed, 16 Dec 2015 12:26:14 -0800
Message-ID: <1450297574.24782.3.camel@perches.com>
References: <1450295919-17292-1-git-send-email-faisal.latif@intel.com>
	 <1450295919-17292-2-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, e1000-rdma@lists.sourceforge.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>
To: Faisal Latif <faisal.latif@intel.com>, dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0103.hostedemail.com ([216.40.44.103]:39140 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966999AbbLPU0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 15:26:19 -0500
In-Reply-To: <1450295919-17292-2-git-send-email-faisal.latif@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 13:58 -0600, Faisal Latif wrote:
> From: Anjali Singhai Jain <anjali.singhai@intel.com>
>=20
> This patch adds a Client interface for i40iw driver
> support. Also expands the Virtchannel to support messages
> from i40evf driver on behalf of i40iwvf driver.
[]
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/=
net/ethernet/intel/i40e/i40e_client.c
[]
> + * Contact Information:
> + * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>

trivia:

This should probably be:=A0intel-wired-lan@lists.osuosl.org
