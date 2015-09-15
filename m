From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Tue, 15 Sep 2015 13:47:32 -0400
Message-ID: <20150915134732.7ff50d03@gandalf.local.home>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
	<27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
	<1442313464.1914.21.camel@sipsolutions.net>
	<20150915110447.GI6350@linux>
	<20150915094509.46cca84d@gandalf.local.home>
	<CA+55aFxVQ9jD=jUqPZt76EMe_Tb-_SA8v=rOHeR9Ljdsc6=xGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Johannes Berg
 <johannes@sipsolutions.net>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>, "linaro-kernel@lists.linaro.org"
 <linaro-kernel@lists.linaro.org>, Rafael Wysocki <rjw@rjwysocki.net>,
 "sboyd@codeaurora.org" <sboyd@codeaurora.org>, "arnd@arndb.de"
 <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Akinobu Mita
 <akinobu.mita@gmail.com>, Alexander Duyck <alexander.h.duyck@redhat.com>,
 "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..."
 <alsa-devel@alsa-project.org>, Andrew Morton <akpm@linux-foundation.org>,
 Andy Lutomirski <luto@amacapital.net>, Arik Nemtsov <arik@wizery.com>,
 "open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER"
 <ath10k@lists.infradead.org>, "open list:QUALCOMM ATHEROS ATH9K WIRELESS
 DRIVER" <ath9k-devel@lists.ath9k.org>, "Altman, Avri"
 <avri.altman@intel.com>, "open list:B43 WIRELE
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CA+55aFxVQ9jD=jUqPZt76EMe_Tb-_SA8v=rOHeR9Ljdsc6=xGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Sep 2015 10:38:32 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:


> But that user interface issue doesn't seem to be the case here, an I
> can't say that I mind the patch. It looks fairly sane.

If Linus is fine with it, I'm fine with it too.

But please, next time, go easy on the Cc list. Maybe just use bcc for
those not on the list, stating that you BCC'd a lot of people to make
sure this is sane, but didn't want to spam everyone with every reply.

What do others think when there's a change that goes across the board
this much? BCC OK with you, as just an FYI, I'm doing this? Or should
just the lists be enough and if you don't see it, too bad?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
