From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH next] drivers/net/wireless/ath/wil6210/debugfs.c: Use
 'uint64_t' instead of 'cycles_t' to avoid warnings
Date: Wed, 24 Dec 2014 23:22:05 +0800
Message-ID: <549ADA1D.8030509@gmail.com>
References: <549AD067.80608@gmail.com> <549AD54F.3020605@gmail.com> <8761d19j6z.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: qca_vkondrat@qca.qualcomm.com, linux-wireless@vger.kernel.org,
	wil6210@qca.qualcomm.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <8761d19j6z.fsf@kamboji.qca.qualcomm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/24/2014 11:11 PM, Kalle Valo wrote:
> Chen Gang <gang.chen.5i5j@gmail.com> writes:
> 
>> Oh, sorry, I forgot the word wrap (after change a new pc). I shall send
>> patch v2 for it.
> 
> While at it, could you also please simplify the title. You don't have to
> put the full directory there, it just makes it more difficult to read.
> This should be enough:
> 
> wil6210: Use 'uint64_t' instead of 'cycles_t' to avoid warnings
> 

Oh, I have sent patch v2, if necessary, I will send patch v3 for it.
(if necessary, please let me know)

> I see quite a few patches with titles like 'drivers: net: wireless: ath:
> fix foo'. Where an earth is that coming from? Bad documentation
> somewhere?
> 

I guess, this can let the patch makers have a easier life, e.g. for me,
I may send patches for various sub-systems (arch/*, drivers/*, net/*,
also another projects ...).

Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
