From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] mlxsw: spectrum: remove redundant check if err is zero
Date: Fri, 23 Sep 2016 14:14:27 +0200
Message-ID: <20160923121426.GA1789@nanopsycho>
References: <20160923110245.18977-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160923110245.18977-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Sep 23, 2016 at 01:02:45PM CEST, colin.king@canonical.com wrote:
>From: Colin Ian King <colin.king@canonical.com>
>
>There is an earlier check and return if err is non-zero, so
>the check to see if it is zero is redundant in every iteration
>of the loop and hence the check can be removed.
>
>Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
