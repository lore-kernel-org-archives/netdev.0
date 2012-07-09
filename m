From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH net-next 04/15] security: Add Linux Security Modules hook
 for AF_BUS sockets
Date: Mon, 9 Jul 2012 13:32:03 +1000 (EST)
Message-ID: <alpine.LRH.2.02.1207091330410.1482@tundra.namei.org>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk> <1340988354-26981-5-git-send-email-vincent.sanders@collabora.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Paul Moore <paul@paul-moore.com>
To: Vincent Sanders <vincent.sanders@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-5-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Jun 2012, Vincent Sanders wrote:

> From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> 
> AF_BUS implements a security hook bus_connect() to be used by LSM to
> enforce connectivity security policies.

Nack.

Changes to LSM should be cc'd the LSM list and Paul Moore.



- James
-- 
James Morris
<jmorris@namei.org>
