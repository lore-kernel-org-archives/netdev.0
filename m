From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH 5/5] net: davinci_mdio: trivial cleanup
Date: Fri, 17 May 2013 10:16:32 +0530
Message-ID: <CA+V-a8sWbUa-uPnto6D3Ncafb_PRb1yTiuF1kFmroU8RVkvh2Q@mail.gmail.com>
References: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
 <1368689438-23889-6-git-send-email-prabhakar.csengg@gmail.com> <51952C3B.80202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51952C3B.80202@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

Thanks for the review.

On Fri, May 17, 2013 at 12:28 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 16-05-2013 11:30, Lad Prabhakar wrote:
>
>> From: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>
>
>> remove unwanted header inclusion and sort the alphabetically
>
>
>    s/the/them/.
OK
>
>
>> also guard the davinci_mdio_of_mtable table and davinci_mdio_probe_dt()
>> with CONFIG_OF.
>
>
>    Saying "also" in the changelog is often a good sign there should be one
> more patch -- as in this case.
>
OK I'll split the patch.

Regards,
--Prabhakar Lad
