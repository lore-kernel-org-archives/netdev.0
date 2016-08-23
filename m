From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] liquidio: declare liquidio_set_rxcsum_command static
Date: Tue, 23 Aug 2016 16:54:12 -0700 (PDT)
Message-ID: <20160823.165412.1206058773072228159.davem@davemloft.net>
References: <1471881120-10232-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471881120-10232-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Mon, 22 Aug 2016 17:52:00 +0200

> liquidio_set_rxcsum_command is a local function only, no need to expose
> it outside of lio_main.c so declare it static and make sparse happy.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied.
