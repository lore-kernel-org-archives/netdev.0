From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: linux-next: manual merge of the net tree with the
 wireless-current tree
Date: Tue, 28 Jun 2011 07:57:14 -0700
Message-ID: <1309273034.13527.0.camel@wwguy-huron>
References: <20110628140219.1480dc7a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110628140219.1480dc7a.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-06-27 at 21:02 -0700, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/wireless/iwlwifi/iwl-tx.c between commits 1107a08a1a3e
> ("iwlagn: fix cmd queue unmap"), e815407d395e ("iwlagn: map command
> buffers BIDI") and 2627c002cbed ("iwlagn: use PCI_DMA_* for pci_*
> operations") from the wireless-current tree and commit 795414db8607
> ("iwlagn: don't use the PCI wrappers for DMA operation") from the net
> tree.
> 
> I fixed it up (I think - see below) and can carry the fix as necessary.

Looks right to me. Thanks for fixing it.

Wey
