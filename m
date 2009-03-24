From: Kumar Gala <galak@kernel.crashing.org>
Subject: make sure ucc_geth.c fixed-link support still works in net-next
Date: Tue, 24 Mar 2009 08:15:13 -0500
Message-ID: <382F4B5D-93C4-41BB-A00A-8A6C240CD170@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: LinuxPPC Mailing List <linuxppc-dev@ozlabs.org>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
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

Anton, Andy

Can you take a look at the recent net-next tree and make sure that the  
merge between the fsl_pq_mdio.c support and the patch that went into  
2.6.29 to fix fixed-link support in ucc_geth.c is correct and still  
works.

See commits:
	Merge branch master... (8be7cdccacfbfc707e7370cad9bb168defed636f)
	ucc_geth: Fix merge error. (039a6f6a39d2aa30ee53afdb213ea6dd4482928b)

- k
