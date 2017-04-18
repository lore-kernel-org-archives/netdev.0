From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH][net-next] esp6: fix incorrect null pointer check on xo
Date: Tue, 18 Apr 2017 23:11:20 +0300
Message-ID: <20170418201119.72la2hstf47dpply@mwanda>
References: <20170418140653.8839-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170418140653.8839-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's in Steffen's tree, not the networking tree and he's not CC'd.  You
should really be adding Fixes tags because it helps to ensure you CC the
guilty parties.

regards,
dan carpenter
