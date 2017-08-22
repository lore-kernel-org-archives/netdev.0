From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ethernet: xircom: small clean up in
 setup_xirc2ps_cs()
Date: Tue, 22 Aug 2017 10:30:18 -0700 (PDT)
Message-ID: <20170822.103018.1072025777350760025.davem@davemloft.net>
References: <20170821094730.ydm2xwsqbkyadybi@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, matvejchikov@gmail.com,
        bhe@redhat.com, akpm@linux-foundation.org, mingo@kernel.org,
        linux-kernel@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821094730.ydm2xwsqbkyadybi@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 21 Aug 2017 12:47:30 +0300

> The get_options() function takes the whole ARRAY_SIZE().  It doesn't
> matter here because we don't use more than 7 elements.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
