From: rapier <rapier@psc.edu>
Subject: Re: [Web10g-user] Web10g TCP statistics patch - mainlining into kernel?
Date: Fri, 25 Jan 2013 15:08:30 -0500
Message-ID: <5102E63E.1020508@psc.edu>
References: <18855.1359138716@turing-police.cc.vt.edu>            <5102DE61.80804@psc.edu> <23149.1359143784@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, web10g-user@web10g.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <23149.1359143784@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 1/25/13 2:56 PM, Valdis.Kletnieks@vt.edu wrote:

> I already looked over the patch and it looks *fairly* sane.  Having said
> that, the best way to proceed for the performance side is probably to
> get some rough ballpark numbers and then get the patch into a state
> that's upstream-able before doing the final measurements (because there's
> actually a high likelihood that the final numbers will end up being
> dependent on the exact details of the patch, plus having more eyeballs on
> it from the netdev side may shake out better approaches).
 >
> Sorry if you've already done all that - I didn't see much evidence of
> it from the web10g-user archives...

The user side of the list has been pretty quiet to be sure. Most of the 
discussion happens internal to the team. The primary KIS developer is 
out the office until next week but I'll try to make sure he addresses 
this as soon as he can. I agree entirely with the more eyes approach and 
none of us have a lot of ego sunk into the details of the code in and of 
itself. As researchers, more than anything else, we want the concept 
moved forward. We believe, strongly, that having these metrics in the 
mainline can really do a lot to help the entire user community and spur 
some really neat development.

Chris
