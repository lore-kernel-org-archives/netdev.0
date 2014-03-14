From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH 3/3] ath10k: add firmware files
Date: Fri, 14 Mar 2014 05:36:53 -0700
Message-ID: <CAB=NE6WW8yX4kdy02j2fT4g0JvYj4a_XkiqYtXKZSMB7FHuwNg@mail.gmail.com>
References: <20140314084501.23100.13103.stgit@x230> <20140314084514.23100.72654.stgit@x230>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	ath10k@lists.infradead.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140314084514.23100.72654.stgit@x230>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 14, 2014 at 1:45 AM, Kalle Valo <kvalo@qca.qualcomm.com> wrote:
> +* No Reverse engineering, decompiling, decrypting, or disassembling of
> +  this software is permitted.

We have other firmware licenses that have this language already on
linux-firmware but let us also keep in mind that linux-firmware will
likely not only be used by Linux folks.

<-- cut -->

> + NO LICENSES OR OTHER RIGHTS,
> +WHETHER EXPRESS, IMPLIED, BASED ON ESTOPPEL OR OTHERWISE, ARE GRANTED
> +TO ANY PARTY'S PATENTS, PATENT APPLICATIONS, OR PATENTABLE INVENTIONS
> +BY VIRTUE OF THIS LICENSE OR THE DELIVERY OR PROVISION BY QUALCOMM
> +ATHEROS, INC. OF THE SOFTWARE.

This -- however is new to linux-firmware -- and I hereby raise a big
red fucking flag. All other licenses on linux-firmware provide at the
very least a limited patent grant. What makes Qualcomm special ?

> +FOR ANY DIRECT DAMAGES ARISING UNDER OR RESULTING FROM
> +THIS AGREEMENT OR IN CONNECTION WITH ANY USE OF THE SOFTWARE SHALL NOT
> +EXCEED A TOTAL AMOUNT OF US$5.00.

WTF - was this inspired by a Sci-Fi movie?

  Luis
