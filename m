From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.14-rc4 0/3] sk98lin: neuter and prepare for removal
Date: Tue, 18 Oct 2005 22:28:55 -0400
Message-ID: <4355AF67.8010604@pobox.com>
References: <10182005213059.12304@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@osdl.org, mlindner@syskonnect.de, rroesler@syskonnect.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932475AbVJSC3B@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <10182005213059.12304@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> These patches take steps towards removing sk98lin from the upstream
> kernel.
> 
> 	-- Remove sk98lin's MODULE_DEVICE_TABLE to avoid
> 	confusing userland tools about which driver to load;
> 
> 	-- Mark sk98lin as Obsolete in the MAINTAINERS file; and,
> 
> 	-- Add sk98lin to the feature-removal-schedule.txt file in the
> 	Documentation directory.
> 
> I accept the possibility that I may be jumping the gun on this.
> However, I think it is worth opening this discussion.

I'll let Stephen make the call on this one (as he did...).

	Jeff
