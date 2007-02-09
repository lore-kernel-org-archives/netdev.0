From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] ethtool: flie option to register dump
Date: Fri, 09 Feb 2007 16:29:01 -0500
Message-ID: <45CCE79D.5070004@garzik.org>
References: <20061018104632.27a37d75@freekitty>	<20061018105022.57b57b6a@freekitty>	<453A63AF.1010505@pobox.com>	<20061023105142.13b507a7@dxpl.pdx.osdl.net> <20061023105703.5f1e13eb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60429 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493AbXBIV3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:29:07 -0500
In-Reply-To: <20061023105703.5f1e13eb@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Add ability to take old raw dumps from a file and decode them.
> It is kind of limited because you still need to have same device
> as the raw file, but useful for maintainers to decode raw dumps.
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> ---
>  ethtool.8 |   13 ++++++++++++-
>  ethtool.c |   43 +++++++++++++++++++++++++++++++++++++------
>  2 files changed, 49 insertions(+), 7 deletions(-)

applied 2-3


