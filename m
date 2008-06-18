From: Sean MacLennan <smaclennan@pikatech.com>
Subject: Re: [PATCH] ibm_emac: Remove the ibm_emac driver
Date: Tue, 17 Jun 2008 20:11:27 -0400
Message-ID: <20080617201127.6388ff78@lappy.seanm.ca>
References: <20080617193523.028d4cc2@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080617193523.028d4cc2@zod.rchland.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Jun 2008 19:35:23 -0400
Josh Boyer <jwboyer@linux.vnet.ibm.com> wrote:

> The arch/ppc sub-tree has been removed in the powerpc git tree.  The
> old ibm_emac driver is no longer used by anything as a result of
> this.  This removes it, leaving the ibm_newemac driver as the proper
> driver to use for PowerPC boards with the EMAC hardware.

Would it make any sense to rename the ibm_newemac driver ibm_emac?

Cheers,
   Sean
