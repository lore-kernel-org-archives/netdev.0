From: Herman Elfrink <herman.elfrink@ti-wmc.nl>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 30 May 2006 09:01:51 +0200
Message-ID: <447BEDDF.2080301@ti-wmc.nl>
References: <44731733.7000204@ti-wmc.nl> <20060523094324.11926fcc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Oosthoek <simon.oosthoek@ti-wmc.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darla.ti-wmc.nl ([217.114.97.45]:29091 "EHLO smtp.wmc")
	by vger.kernel.org with ESMTP id S932147AbWE3HBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 03:01:52 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060523094324.11926fcc@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>Didn't you just reinvent 802.1d bridging? and/or WDS?
>
>  
>

Hi Stephen,

Yes, more or less, but with a twist.
802.1D does not allow retransmitting over the same interface  (which is 
what basically happens in mesh networks), and WDS uses static 
configuration of neighbouring hops (we want to support dynamically 
changing configurations).

Regards,

Herman.
