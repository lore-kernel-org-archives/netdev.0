From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] net: wireless: ath: ath10k: remove unnecessary code
Date: Tue, 9 May 2017 05:33:28 +0000
Message-ID: <87lgq6387s.fsf@kamboji.qca.qualcomm.com>
References: <20170509042159.GA19727@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509042159.GA19727@embeddedgus> (Gustavo A. R. Silva's
        message of "Mon, 8 May 2017 23:21:59 -0500")
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <garsilva@embeddedor.com> writes:

> The name of an array used by itself will always return the array's addres=
s.
> So these tests will always evaluate as false and therefore the _return_
> will never be executed.
>
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

I don't understand the commit log, especially what does "The name of an
array used by itself" mean?

--=20
Kalle Valo=
