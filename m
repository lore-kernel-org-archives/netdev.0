From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] net: wireless: ipw2x00: ipw2200.c:  Remove unused function
Date: Tue, 06 Jan 2015 20:04:41 +0200
Message-ID: <8761cjzsxy.fsf@kamboji.qca.qualcomm.com>
References: <1419078599-31118-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419078599-31118-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	(Rickard Strandqvist's message of "Sat, 20 Dec 2014 13:29:59 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> writes:

> Remove the function ipw_alive() that is not used anywhere.
>
> This was partially found by using a static code analysis program called cppcheck.
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Please improve the patch title and make it more unique like:

ipw2200: remove unused ipw_alive()

-- 
Kalle Valo
