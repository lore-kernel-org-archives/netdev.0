From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/7] Add RSS to DPAA 1.x Ethernet driver
Date: Thu, 24 Aug 2017 09:42:20 -0700 (PDT)
Message-ID: <20170824.094220.1750290899777462105.davem@davemloft.net>
References: <1503559708-13405-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503559708-13405-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Thu, 24 Aug 2017 10:28:21 +0300

> This patch set introduces Receive Side Scaling for the DPAA Ethernet
> driver. Documentation is updated with details related to the new
> feature and limitations that apply.
> Added also a small fix.
> 
> v2: removed a C++ style comment
> v3: move struct fman to header file to avoid exporting a function

Series applied, thanks.
