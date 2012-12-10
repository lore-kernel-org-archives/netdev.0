From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: linux-next: manual merge of the net-next tree with the pci tree
Date: Mon, 10 Dec 2012 06:44:45 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB3018FADD5@HASMSX103.ger.corp.intel.com>
References: <20121210120825.49096bafd378139e98becb8d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"Berg, Johannes" <johannes.berg@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20121210120825.49096bafd378139e98becb8d@canb.auug.org.au>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/wireless/iwlwifi/pcie/trans.c between commit b9d146e30a2d
> ("iwlwifi: collapse wrapper for pcie_capability_read_word()") from the pci
> tree and commit 7afe3705cd4e ("iwlwifi: continue clean up -
> pcie/trans.c") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action is
> required).
> 
Looks right - thanks Stephen!
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
