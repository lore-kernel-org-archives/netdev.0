From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Tue, 13 Aug 2002 21:34:50 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020813113450.GA19058@anakin.wychk.org>
References: <20020813053704.GA14788@anakin.wychk.org> <200208131017.OAA20516@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208131017.OAA20516@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

> > Is that what you expected?
> 
> Well, it proves that one of us makes tests not on linux.
> 


Ah, yes you're right. I was feeling stupid and I forgot to clear the
errno because re-trying the connect().

It looks my brain has gone mouldy. Sorry. :-)



	-- G.
