From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH 2/5] net: davinci_emac: remove unwanted header inclusion
 and sort the alphabetically
Date: Fri, 17 May 2013 10:23:16 +0530
Message-ID: <CA+V-a8vWLWXL7WP3dzKXM0yFAkoU4UxfaqJ4E1t0gQhRp8zj-w@mail.gmail.com>
References: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
 <1368689438-23889-3-git-send-email-prabhakar.csengg@gmail.com> <51952BA2.9040900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51952BA2.9040900@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

Thanks for the review.

On Fri, May 17, 2013 at 12:25 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 16-05-2013 11:30, Lad Prabhakar wrote:
>
>> From: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>
>
>> This patch removes unwanted header inclusion
>
>
>    Why are they unwanted?
>
The driver builds without this includes.

This is arguable, if I would have added a new driver with the only
#includes which were required to build thats accepted. But when I remove
unnecessary #includes from the existing drivers that's not acceptable ?

This applies to rest of the similar patches in the series.

>> and sorts them alphabetically
>
>
>    In the subject you typed "the" instead of "them".
>
Hmm carry forwarded this copy paste error every where will fix it in V2.

Regards,
--Prabhakar Lad
