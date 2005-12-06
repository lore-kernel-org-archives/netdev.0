From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 12/14] spidernet: check if firmware was loaded correctly
Date: Tue, 6 Dec 2005 11:59:11 +1100
Message-ID: <17300.57951.373636.507621@cargo.ozlabs.ibm.com>
References: <20051206035220.097737000@localhost>
	<20051206040645.193163000@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc64-dev@ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arndb@de.ibm.com>, Jens.Osterkamp@de.ibm.com
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <20051206040645.193163000@localhost>
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

Arnd Bergmann writes:

> Uploading the device firmware may fail if wrong input data
> was provided by the user. This checks for the condition.
> 
> From: Jens.Osterkamp@de.ibm.com
> Cc: netdev@vger.kernel.org

This one should be sent to Jeff Garzik, along with patches 11, 13 and
14.

Paul.
