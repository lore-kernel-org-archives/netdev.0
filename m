From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 0/18] Updates & bug fixes for iseries_veth network driver
Date: Thu,  1 Sep 2005 11:28:53 +1000 (EST)
Message-ID: <1125538127.859382.875909607846.qpush@concordia>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc64-dev@ozlabs.org
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: <jgarzik@pobox.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Hi,

This is a series of patches for the iseries_veth driver. Most of these are
pretty much unchanged since I posted them earlier:
http://www.uwsg.iu.edu/hypermail/linux/kernel/0506.3/1837.html

I've added patches to add sysfs support, and do some further code cleanups.

Please merge if they look ok.

cheers
