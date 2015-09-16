From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Wed, 16 Sep 2015 10:02:18 +0200
Message-ID: <20150916080218.GA8155@gmail.com>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
 <27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
 <1442313464.1914.21.camel@sipsolutions.net>
 <20150915110447.GI6350@linux>
 <20150915094509.46cca84d@gandalf.local.home>
 <CA+55aFxVQ9jD=jUqPZt76EMe_Tb-_SA8v=rOHeR9Ljdsc6=xGQ@mail.gmail.com>
 <20150915134732.7ff50d03@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	"sboyd@codeaurora.org" <sboyd@codeaurora.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Mark Brown <broonie@kernel.org>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Arik Nemtsov <arik@wizery.com>,
	"open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>,
	"open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER" <ath9k-devel@lists.ath9k.org>,
	"Altman, A
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20150915134732.7ff50d03@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


* Steven Rostedt <rostedt@goodmis.org> wrote:

> But please, next time, go easy on the Cc list. Maybe just use bcc for those not 
> on the list, stating that you BCC'd a lot of people to make sure this is sane, 
> but didn't want to spam everyone with every reply.

Not just that, such a long Cc: list is a semi-guarantee that various list engines 
(vger included I think) would drop the mail as spam and nobody else would get the 
mail...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
