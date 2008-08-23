From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Fri, 22 Aug 2008 23:56:54 -0700
Message-ID: <86802c440808222356r716fe370v49519486ae74aa30@mail.gmail.com>
References: <773466.71707.qm@web82102.mail.mud.yahoo.com>
	 <86802c440808222241k36c95cd2h8e24031be1dc7b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, "Vivek Goyal" <vgoyal@redhat.com>,
	"Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753486AbYHWG5O@vger.kernel.org>
In-Reply-To: <86802c440808222241k36c95cd2h8e24031be1dc7b8@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please send out after booting with hpet=disable
lspci -tv
lspci -vvxxx

YH
