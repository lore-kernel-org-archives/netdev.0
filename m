From: Federico Vaga <federico.vaga@gmail.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 12:17:36 +0200
Message-ID: <1634770.3jzQipHk0k@harkonnen>
References: <3170667.1PZa2330KE@harkonnen> <5059693.iaLYtpk3E4@harkonnen> <20120620.025837.721158723130014230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: mkl@pengutronix.de, bhupesh.sharma@st.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, giancarlo.asnaghi@st.com,
	wg@grandegger.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120620.025837.721158723130014230.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Why would you try to be generic by using an interface currently
> only available on certain platforms?

I know, I was wrong.

> That is how you make drivers non-portable, and not generic.

Now is fixed in my mind; I learn the lesson.

-- 
Federico Vaga
