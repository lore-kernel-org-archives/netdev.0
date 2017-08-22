From: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Subject: Re: [PATCH v12 7/8] wireless: ipw2200: Replace PCI pool old API
Date: Tue, 22 Aug 2017 18:11:14 -0400
Message-ID: <CA++WF2MAT3aHd3TYfLgym9ssFKBsti6+t9b1yJ_eXHEmRBWwcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Romain Perier <romain.perier@collabora.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22 August 2017 at 07:47, Romain Perier <romain.perier@collabora.com> wrote:
> The PCI pool API is deprecated. This commit replaces the PCI pool old
> API by the appropriate function with the DMA pool API.
>
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> ---
>  drivers/net/wireless/intel/ipw2x00/ipw2200.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
>

Acked-by: Stanislav Yakovlev <stas.yakovlev@gmail.com>

Thanks, and sorry for the long review.

Kalle, could you please apply it to the wireless-drivers-next tree?

Thanks,
Stanislav.
