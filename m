From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/7] Add RSS to DPAA 1.x Ethernet driver
Date: Mon, 28 Aug 2017 16:41:38 -0700 (PDT)
Message-ID: <20170828.164138.1780653981574209650.davem@davemloft.net>
References: <1503839623-3906-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503839623-3906-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Sun, 27 Aug 2017 16:13:36 +0300

> This patch set introduces Receive Side Scaling for the DPAA Ethernet
> driver. Documentation is updated with details related to the new
> feature and limitations that apply.
> Added also a small fix.
> 
> v2: removed a C++ style comment
> v3: move struct fman to header file to avoid exporting a function
> v4: addressed compilation issues introduced in v3

Series applied, thanks.
