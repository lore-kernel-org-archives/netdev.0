From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCHv2 net 3/4] net/mlx4_en: Implement ndo_gso_check()
Date: Sun, 16 Nov 2014 11:32:30 +0200
Message-ID: <CAJ3xEMg4cUmrMtx_CjejKF326yf1_7uNRzudU45Z8m+ggqrQ4Q@mail.gmail.com>
References: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
	<1415925495-59312-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"sathya.perla" <sathya.perla@emulex.com>,
	"shahed.shaikh" <shahed.shaikh@qlogic.com>,
	Amir Vadai <amirv@mellanox.com>,
	dept-gelinuxnicdev <Dept-GELinuxNICDev@qlogic.com>,
	Tom Herbert <therbert@google.com>, alexander.duyck@gmail.com,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415925495-59312-4-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 2:38 AM, Joe Stringer <joestringer@nicira.com> wrote:
> Use vxlan_gso_check() to advertise offload support for this NIC.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

FWIW (since the patches is applied already...)

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

thanks for addressing this piece.
