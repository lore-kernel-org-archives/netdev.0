From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] b43legacy: Remove unused function
Date: Tue, 6 Jan 2015 19:19:52 +0100
Message-ID: <CACna6ryS_+eYi3ODXMngCxwoe8JLuWQyaCNNmhJFHM+g7H_Xzw@mail.gmail.com>
References: <1420567175-17323-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	b43-dev <b43-dev@lists.infradead.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420567175-17323-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6 January 2015 at 18:59, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> Remove the function b43legacy_radio_set_tx_iq() that is not used anyw=
here.
>
> This was partially found by using a static code analysis program call=
ed cppcheck.
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigit=
al.se>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
