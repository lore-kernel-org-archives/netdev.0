From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH] add modalias info to mv643xx_eth.ko
Date: Fri, 18 Jan 2008 09:31:21 -0700
Message-ID: <20080118163121.GA7720@farnsworth.org>
References: <20080118093805.GA28004@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Olaf Hering <olaf@aepfle.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20080118093805.GA28004@aepfle.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 18, 2008 at 10:38:05AM +0100, Olaf Hering wrote:
> mv643xx_eth has an platform modalias file in sysfs.
> But the module itself has no alias: line. Autoloading fails
> without the alias info in the module.
> 
> Signed-off-by: Olaf Hering <olaf@aepfle.de>

Acked-by: Dale Farnsworth <dale@farnsworth.org>
