From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] mvneta: remove double validation of mac address
Date: Wed, 30 Oct 2013 00:35:21 +0100
Message-ID: <20131030003521.6ada83a5@skate>
References: <1383081906-12342-1-git-send-email-laurent.navet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Laurent Navet <laurent.navet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383081906-12342-1-git-send-email-laurent.navet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Laurent Navet,

On Tue, 29 Oct 2013 22:25:06 +0100, Laurent Navet wrote:
> Mac address validity is already checked in of_get_mac_address().
> No need to do it twice.
> 
> Signed-off-by: Laurent Navet <laurent.navet@gmail.com>

Thanks, but an identical patch has been posted by Luka Perkov
<luka@openwrt.org> just a few days ago. See
http://www.spinics.net/lists/netdev/msg255454.html.

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
