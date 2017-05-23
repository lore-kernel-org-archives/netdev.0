From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH 0/5] net-SCTP: Adjustments for three function implementations
Date: Tue, 23 May 2017 14:34:11 +0800
Message-ID: <CADvbK_dm4trRsUsbGaMih741=u+ZOUCbPiGODQ0NMdJYLx+SOQ@mail.gmail.com>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-sctp@vger.kernel.org, network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 12:35 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 18:30:45 +0200
>
> A few update suggestions were taken into account
> from static source code analysis.
>
> Markus Elfring (5):
>   Use kmalloc_array() in sctp_init()
>   Delete an error message for a failed memory allocation in sctp_init()
>   Fix a typo in a comment line in sctp_init()
>   Improve a size determination in sctp_inetaddr_event()
>   Adjust one function call together with a variable assignment
>
>  net/sctp/protocol.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
I guess these patches are for net-next.git

Series Reviewed-by: Xin Long <lucien.xin@gmail.com>

>
> --
> 2.13.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
