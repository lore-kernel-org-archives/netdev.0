From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v2] mlx5: Add ndo_poll_controller() implementation
Date: Wed, 28 Sep 2016 11:43:43 +0300
Message-ID: <CALzJLG85SYxf7P-GEdQvDxfUCXr-OXyek_R8LTSgQs30t2ME2Q@mail.gmail.com>
References: <CALzJLG8o3dfPJR-2iaWb-s7r65r51HhgTs5Srf92-Tx0sZCSHw@mail.gmail.com>
 <df7c9e07a041523e13be905d00e74007ecb88c6b.1475014333.git.calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@fb.com
To: Calvin Owens <calvinowens@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <df7c9e07a041523e13be905d00e74007ecb88c6b.1475014333.git.calvinowens@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 28, 2016 at 1:23 AM, Calvin Owens <calvinowens@fb.com> wrote:
> This implements ndo_poll_controller in net_device_ops callback for mlx5,
> which is necessary to use netconsole with this driver.
>
> Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>
> Signed-off-by: Calvin Owens <calvinowens@fb.com>

Acked-By: Saeed Mahameed <saeedm@mellanox.com>
