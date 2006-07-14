From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: Netem does not work with loopback
Date: Fri, 14 Jul 2006 20:49:36 +0200
Message-ID: <44B7E740.5090004@yahoo.fr>
References: <44B7AB76.2030700@yahoo.fr>	<20060714083847.6997a460@localhost.localdomain>	<44B7CE81.8020800@yahoo.fr> <20060714113900.029e6a2f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:59310 "EHLO smtp4-g19.free.fr")
	by vger.kernel.org with ESMTP id S1161281AbWGNSse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 14:48:34 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060714113900.029e6a2f@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> No, the correct fix is to make IP input not accept any options from the
> device.
OK.
>   Does this work?
>   
Yes it does. Thank you very much.

-- 
Guillaume

