From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [GIT] Networking
Date: Wed, 20 Feb 2013 22:55:38 -0500
Message-ID: <CAP=VYLoMFXt7=MAdb-5uk6n8qiaG_99gw8haOjXDrYvzVSyvnQ@mail.gmail.com>
References: <20130220.170901.343210063003534302.davem@davemloft.net> <CA+55aFz=tzf9a-SY1CqCAxsqRDz=ebE69YoZ30at6kHeKKhsaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFz=tzf9a-SY1CqCAxsqRDz=ebE69YoZ30at6kHeKKhsaA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 20, 2013 at 10:05 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Feb 20, 2013 at 2:09 PM, David Miller <davem@davemloft.net> wrote:
>>
>> 15) Orphan and delete a bunch of pre-historic networking drivers from
>>     Paul Gortmaker.
>
> Nooo.... You killed the 3c501 and 3c503 drivers! Snif.

Not true!  They were dead long ago, and here we were just providing
the service of a coroner, by removing the bodies vs. having them left to
decompose on the side of the street.

Paul.
--

>
> I wonder if they still worked..
>
>              Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
