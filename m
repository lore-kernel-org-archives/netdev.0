From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30-rc5] ehea: fix invalid pointer access
Date: Mon, 04 May 2009 11:07:01 -0700 (PDT)
Message-ID: <20090504.110701.11718010.davem@davemloft.net>
References: <200905041802.30527.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: themann@de.ibm.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	raisch@de.ibm.com, ossrosch@linux.vnet.ibm.com,
	linuxppc-dev@ozlabs.org, ossthema@de.ibm.com, osstklei@de.ibm.com
To: hannes.hering@linux.vnet.ibm.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <200905041802.30527.hannes.hering@linux.vnet.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Date: Mon, 4 May 2009 18:02:30 +0200

> This patch fixes an invalid pointer access in case the receive queue holds no
> pointer to the next skb when the queue is empty.
> 
> Signed-off-by: Hannes Hering <hering2@de.ibm.com>
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

Applied, thanks.
