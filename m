From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [RFC] network device ops phase 1
Date: Fri, 14 Nov 2008 00:11:31 -0600
Message-ID: <1032EE32-F448-47F0-9604-4C6FF2CD8EBC@kernel.crashing.org>
References: <20081107155023.2dea5e0f@extreme>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45712 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbYKNGLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 01:11:37 -0500
In-Reply-To: <20081107155023.2dea5e0f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 7, 2008, at 5:50 PM, Stephen Hemminger wrote:

> +
> +/*
> + * This structure defines the management hooks for network devices.
> + * The following hooks can bed defined and are optonal (can be null)

s/bed/be/, /optonal/optional/

>
> + * unless otherwise noted.
> + *

- k
