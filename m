From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 2.6.13-rc6-mm1: why is PHYLIB a user-visible option?
Date: Fri, 19 Aug 2005 20:29:03 -0400
Message-ID: <4306794F.4080402@pobox.com>
References: <20050819043331.7bc1f9a9.akpm@osdl.org> <20050820002027.GJ3615@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932766AbVHTA3S@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050820002027.GJ3615@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Is there any reason why PHYLIB is a user-visible option?
> 
> As far as I understand it, PHYLIB and the MII PHY device drivers are an 
> internal library drivers should start to use roughly similar to MII.
> 
> But in this case, the options shouldn't be user-visible.

This code is still shaking out, so don't worry much about it right now.

	Jeff
