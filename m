From: "John Ronciak" <john.ronciak@gmail.com>
Subject: Re: [PATCH] e1000: Support e1000 OEMed onto Aculab cards
Date: Mon, 27 Feb 2006 16:31:32 -0800
Message-ID: <56a8daef0602271631y6925bdcdr7a62db920d4b1715@mail.gmail.com>
References: <20060227220517.GA8611@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751852AbWB1Abe@vger.kernel.org>
To: cramerj@intel.com, john.ronciak@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, broonie@sirena.org.uk
In-Reply-To: <20060227220517.GA8611@sirena.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please don't apply this patch.  We have taken this offline at the
moment to work this out with the OEM, Aculab.  They have made
modification to how the Intel controller operates which may make it
have problems with the normal e1000 driver.  We are in contact with
both Mark and Aculab about this offline.  The last thing Aculab talked
to us about was to make sure that the normal Intel e1000 drivers did
_not_ work with their hardware, hence the device ID change.  We'll
continue this on this thread if this turns out not to be the case.  We
(Intel) also don't know exactly how they changed the behavior of the
hardware which is another topic for us to talk about.

Thanks.
--
Cheers,
John
